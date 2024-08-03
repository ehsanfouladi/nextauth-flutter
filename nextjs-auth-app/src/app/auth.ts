import NextAuth from 'next-auth';
import { SupabaseAdapter } from '@auth/supabase-adapter';
import { authConfig } from './auth.config';
 
export const { handlers, signIn, signOut, auth } = NextAuth({
  ...authConfig,
  adapter: SupabaseAdapter({
    url: process.env.SUPABASE_URL!,
    secret: process.env.SUPABASE_SECRET!,
  }),
  callbacks: {
    session({ session, user }) {
      session.user.id = user.id
      return session
    },
  },
  debug: process.env.NODE_ENV === "development",
  secret: process.env.NEXTAUTH_SECRET,
})
