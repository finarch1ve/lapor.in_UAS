-- =====================================================
-- 1. USERS TABLE (Extended auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'helpdesk', 'admin')),
    student_id TEXT,
    class_name TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can view own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- Admin can read all users
CREATE POLICY "Admin can view all users"
    ON public.users FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Admin can update any user
CREATE POLICY "Admin can update users"
    ON public.users FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 2. TICKETS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.tickets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'Menunggu' CHECK (status IN ('Menunggu', 'Diproses', 'Selesai')),
    category TEXT NOT NULL CHECK (category IN ('Hardware', 'Software', 'Network', 'Lainnya')),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    helpdesk_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    image_url TEXT,
    is_deleted BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;

-- Users can view their own tickets
CREATE POLICY "Users can view own tickets"
    ON public.tickets FOR SELECT
    USING (auth.uid() = user_id);

-- Helpdesk can view assigned tickets
CREATE POLICY "Helpdesk can view assigned tickets"
    ON public.tickets FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'helpdesk'
        )
        AND helpdesk_id = auth.uid()
    );

-- Admin can view all tickets
CREATE POLICY "Admin can view all tickets"
    ON public.tickets FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Users can create tickets
CREATE POLICY "Users can create tickets"
    ON public.tickets FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Helpdesk can update assigned tickets
CREATE POLICY "Helpdesk can update assigned tickets"
    ON public.tickets FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'helpdesk'
        )
        AND helpdesk_id = auth.uid()
    );

-- Admin can update any ticket
CREATE POLICY "Admin can update tickets"
    ON public.tickets FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 3. COMMENTS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    user_name TEXT NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;

-- Users can view comments for tickets they can access
CREATE POLICY "Users can view accessible comments"
    ON public.comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tickets
            WHERE tickets.id = comments.ticket_id
            AND (tickets.user_id = auth.uid() OR tickets.helpdesk_id = auth.uid())
        )
        OR EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Users can create comments on accessible tickets
CREATE POLICY "Users can create comments"
    ON public.comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- 4. TICKET HISTORY TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.ticket_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE NOT NULL,
    action TEXT NOT NULL,
    performed_by UUID REFERENCES public.users(id) ON DELETE SET NULL NOT NULL,
    performed_by_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.ticket_history ENABLE ROW LEVEL SECURITY;

-- Users can view history for accessible tickets
CREATE POLICY "Users can view accessible history"
    ON public.ticket_history FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.tickets
            WHERE tickets.id = ticket_history.ticket_id
            AND (tickets.user_id = auth.uid() OR tickets.helpdesk_id = auth.uid())
        )
        OR EXISTS (
            SELECT 1 FROM public.users
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- =====================================================
-- 5. NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('status', 'comment', 'assign')),
    ticket_id UUID REFERENCES public.tickets(id) ON DELETE CASCADE,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Users can view their own notifications
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

-- Users can update their own notifications
CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

-- =====================================================
-- 6. STORAGE BUCKETS
-- =====================================================

-- Create storage bucket for ticket images
INSERT INTO storage.buckets (id, name, public)
VALUES ('ticket_images', 'ticket_images', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for user avatars
INSERT INTO storage.buckets (id, name, public)
VALUES ('user_avatars', 'user_avatars', true)
ON CONFLICT (id) DO NOTHING;

-- Storage policies for ticket_images
CREATE POLICY "Users can upload ticket images"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'ticket_images');

CREATE POLICY "Anyone can view ticket images"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'ticket_images');

-- Storage policies for user_avatars
CREATE POLICY "Users can upload own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'user_avatars');

CREATE POLICY "Anyone can view avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'user_avatars');

-- =====================================================
-- 7. FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tickets table
CREATE TRIGGER update_tickets_updated_at
    BEFORE UPDATE ON public.tickets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Apply to users table
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Function to create user entry after signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, name, role)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
        'user'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user entry on signup
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- =====================================================
-- 8. SEED DATA (Optional - for testing)
-- =====================================================

-- Create admin user (you need to sign up first, then run this)
-- UPDATE public.users SET role = 'admin' WHERE email = 'admin@example.com';

-- Create helpdesk user (you need to sign up first, then run this)
-- UPDATE public.users SET role = 'helpdesk' WHERE email = 'helpdesk@example.com';

-- =====================================================
-- 9. INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_tickets_user_id ON public.tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_helpdesk_id ON public.tickets(helpdesk_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON public.tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_created_at ON public.tickets(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comments_ticket_id ON public.comments(ticket_id);
CREATE INDEX IF NOT EXISTS idx_history_ticket_id ON public.ticket_history(ticket_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON public.notifications(is_read);

-- =====================================================
-- END OF SCHEMA
-- =====================================================
