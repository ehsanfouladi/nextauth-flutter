import { cookies } from 'next/headers';
import ClientSessionPage from './client-session';

export default async function ErrorPage() {
  const cookieStore = cookies();
  const secureCookie = process.env.AUTH_URL?.startsWith("https://");
  const nextAuthcookieName = secureCookie
    ? "__Secure-next-auth"
    : "next-auth";
  const sessionToken = cookieStore.get(`${nextAuthcookieName}.session-token`)?.value || null;

  return (
    <ClientSessionPage sessionToken={sessionToken} />
  );
}
