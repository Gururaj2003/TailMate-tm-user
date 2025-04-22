-- Drop existing tables if they exist (to start fresh)
DROP TABLE IF EXISTS public.chat_history CASCADE;
DROP TABLE IF EXISTS public.bookings CASCADE;
DROP TABLE IF EXISTS public.services CASCADE;
DROP TABLE IF EXISTS public.service_providers CASCADE;
DROP TABLE IF EXISTS public.pets CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE public.profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT,
    email TEXT,
    phone_number TEXT,
    address TEXT,
    profile_image TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create pets table
CREATE TABLE public.pets (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    breed TEXT,
    birth_date TIMESTAMP WITH TIME ZONE,
    weight REAL,
    gender TEXT,
    color TEXT,
    medical_history TEXT,
    special_instructions TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create service_providers table (read-only for users)
CREATE TABLE public.service_providers (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    address TEXT,
    latitude REAL,
    longitude REAL,
    rating REAL DEFAULT 0.0,
    total_ratings INTEGER DEFAULT 0,
    profile_image TEXT,
    is_verified BOOLEAN DEFAULT false,
    service_ids UUID[],
    specialties TEXT[],
    description TEXT,
    price_multiplier REAL DEFAULT 1.0,
    location TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create services table (read-only for users)
CREATE TABLE public.services (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    provider_id UUID REFERENCES public.service_providers(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    price REAL NOT NULL,
    duration INTEGER,
    category TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create bookings table
CREATE TABLE public.bookings (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    provider_id UUID REFERENCES public.service_providers(id) ON DELETE CASCADE,
    service_id UUID REFERENCES public.services(id) ON DELETE CASCADE,
    pet_id UUID REFERENCES public.pets(id) ON DELETE CASCADE,
    booking_date TEXT NOT NULL,
    booking_time TEXT NOT NULL,
    status TEXT DEFAULT 'pending',
    payment_status TEXT DEFAULT 'pending',
    amount REAL NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create chat_history table
CREATE TABLE public.chat_history (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    sender_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    receiver_id UUID REFERENCES public.service_providers(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.service_providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can view their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can insert their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can update their own pets" ON public.pets;
DROP POLICY IF EXISTS "Users can delete their own pets" ON public.pets;
DROP POLICY IF EXISTS "Allow all operations on pets" ON public.pets;
DROP POLICY IF EXISTS "Anyone can view service providers" ON public.service_providers;
DROP POLICY IF EXISTS "Only service providers can update their own profile" ON public.service_providers;
DROP POLICY IF EXISTS "Service providers can insert their profile" ON public.service_providers;
DROP POLICY IF EXISTS "Anyone can view services" ON public.services;
DROP POLICY IF EXISTS "Service providers can manage their own services" ON public.services;
DROP POLICY IF EXISTS "Users can view their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can create bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can update their own bookings" ON public.bookings;
DROP POLICY IF EXISTS "Service providers can view their bookings" ON public.bookings;
DROP POLICY IF EXISTS "Service providers can update their bookings" ON public.bookings;
DROP POLICY IF EXISTS "Users can view their own chat history" ON public.chat_history;
DROP POLICY IF EXISTS "Users can send messages" ON public.chat_history;
DROP POLICY IF EXISTS "Service providers can view their chat history" ON public.chat_history;

-- Create RLS Policies
-- Profiles policies (User can manage their own profile)
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile"
    ON public.profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Pets policies (User can manage their own pets)
CREATE POLICY "Users can view their own pets"
    ON public.pets FOR SELECT
    USING (auth.uid() = owner_id);

CREATE POLICY "Users can insert their own pets"
    ON public.pets FOR INSERT
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Users can update their own pets"
    ON public.pets FOR UPDATE
    USING (auth.uid() = owner_id);

CREATE POLICY "Users can delete their own pets"
    ON public.pets FOR DELETE
    USING (auth.uid() = owner_id);

-- Service providers policies (Read-only for users)
CREATE POLICY "Anyone can view service providers"
    ON public.service_providers FOR SELECT
    USING (true);

-- Services policies (Read-only for users)
CREATE POLICY "Anyone can view services"
    ON public.services FOR SELECT
    USING (true);

-- Bookings policies (User can manage their own bookings)
CREATE POLICY "Users can view their own bookings"
    ON public.bookings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create bookings"
    ON public.bookings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own bookings"
    ON public.bookings FOR UPDATE
    USING (auth.uid() = user_id);

-- Chat history policies (User can manage their own chats)
CREATE POLICY "Users can view their own chat history"
    ON public.chat_history FOR SELECT
    USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Users can send messages"
    ON public.chat_history FOR INSERT
    WITH CHECK (auth.uid() = sender_id);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_profiles_id ON public.profiles(id);
CREATE INDEX IF NOT EXISTS idx_pets_owner_id ON public.pets(owner_id);
CREATE INDEX IF NOT EXISTS idx_services_provider_id ON public.services(provider_id);
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON public.bookings(user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_provider_id ON public.bookings(provider_id);
CREATE INDEX IF NOT EXISTS idx_bookings_service_id ON public.bookings(service_id);
CREATE INDEX IF NOT EXISTS idx_bookings_pet_id ON public.bookings(pet_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_sender_id ON public.chat_history(sender_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_receiver_id ON public.chat_history(receiver_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_created_at ON public.chat_history(created_at);

-- Create functions for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pets_updated_at
    BEFORE UPDATE ON public.pets
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_providers_updated_at
    BEFORE UPDATE ON public.service_providers
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_services_updated_at
    BEFORE UPDATE ON public.services
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at
    BEFORE UPDATE ON public.bookings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Insert sample service providers and services (read-only data)
INSERT INTO public.service_providers (id, name, email, phone, address, rating, total_ratings, is_verified, service_ids, specialties, description, price_multiplier, location)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'Happy Paws Services', 'happy@paws.com', '1234567890', '123 Pet Street', 4.8, 156, true, 
     ARRAY[CAST('11111111-1111-1111-1111-111111111111' AS UUID), CAST('22222222-2222-2222-2222-222222222222' AS UUID)],
     ARRAY['Pet Walking', 'Pet Sitting'],
     'Professional pet care services with years of experience', 1.0, '123 Pet Street'),
    ('22222222-2222-2222-2222-222222222222', 'Pawsome Groomers', 'groom@pawsome.com', '0987654321', '456 Animal Avenue', 4.9, 203, true,
     ARRAY[CAST('33333333-3333-3333-3333-333333333333' AS UUID), CAST('44444444-4444-4444-4444-444444444444' AS UUID)],
     ARRAY['Grooming', 'Bathing'],
     'Expert grooming services for all breeds', 1.2, '456 Animal Avenue'),
    ('33333333-3333-3333-3333-333333333333', 'Pet Care Experts', 'care@petexperts.com', '1122334455', '789 Animal Care Road', 4.7, 189, true,
     ARRAY[CAST('55555555-5555-5555-5555-555555555555' AS UUID), CAST('66666666-6666-6666-6666-666666666666' AS UUID)],
     ARRAY['Pet Sitting', 'Pet Training'],
     'Comprehensive pet care and training services', 1.1, '789 Animal Care Road'),
    ('44444444-4444-4444-4444-444444444444', 'VetCare Plus', 'info@vetcare.com', '5566778899', '321 Vet Street', 4.9, 245, true,
     ARRAY[CAST('77777777-7777-7777-7777-777777777777' AS UUID), CAST('88888888-8888-8888-8888-888888888888' AS UUID)],
     ARRAY['Veterinary Care', 'Health Checkups'],
     'Professional veterinary services and health checkups', 1.3, '321 Vet Street')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.services (id, provider_id, name, description, price, duration, category)
VALUES 
    ('11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 'Pet Walking', '30-minute walk for your pet', 20.00, 30, 'walking'),
    ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Pet Sitting', 'In-home pet sitting service', 40.00, 60, 'sitting'),
    ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', 'Basic Grooming', 'Basic grooming package', 50.00, 60, 'grooming'),
    ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Premium Grooming', 'Premium grooming package', 80.00, 90, 'grooming'),
    ('55555555-5555-5555-5555-555555555555', '33333333-3333-3333-3333-333333333333', 'Pet Sitting', 'Overnight pet sitting', 60.00, 1440, 'sitting'),
    ('66666666-6666-6666-6666-666666666666', '33333333-3333-3333-3333-333333333333', 'Basic Training', 'Basic obedience training', 45.00, 60, 'training'),
    ('77777777-7777-7777-7777-777777777777', '44444444-4444-4444-4444-444444444444', 'Health Checkup', 'Basic health checkup', 35.00, 30, 'healthcare'),
    ('88888888-8888-8888-8888-888888888888', '44444444-4444-4444-4444-444444444444', 'Vaccination', 'Pet vaccination service', 25.00, 15, 'healthcare')
ON CONFLICT (id) DO NOTHING; 