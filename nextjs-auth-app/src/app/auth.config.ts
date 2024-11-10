import type { NextAuthConfig } from 'next-auth';
// import GoogleProvider from 'next-auth/providers/google';
import KeycloakProvider from "next-auth/providers/keycloak";

export const authConfig = {
  callbacks: {
    session({ session, user }) {
      session.user.id = user.id
      return session
    },
  },
  providers: [
    KeycloakProvider({
      clientId: 'public-mobile',
      clientSecret:'',
      issuer: 'https://test.shamsiran.com/realms/identity',
    })
  ],
} satisfies NextAuthConfig;
