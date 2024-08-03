import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import NextAuth from "next-auth";
import { authConfig } from "./app/auth.config";

const { auth } = NextAuth(authConfig);

export default auth(async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  
  const secureCookie = process.env.AUTH_URL?.startsWith("https://");
  const nextAuthcookieName = secureCookie
    ? "__Secure-next-auth"
    : "next-auth";
  
  const sessionToken = req.cookies.get(`${nextAuthcookieName}.session-token`)?.value || null;

  if (sessionToken && req.nextUrl.pathname === "/auth/mobile/login") {
    return NextResponse.redirect(new URL("/", req.url));
  }

  if (!sessionToken && req.nextUrl.pathname !== "/auth/mobile/login") {
    return NextResponse.redirect(new URL("/mobile/login", req.url));
  }

  return res;
});

export const config = {
  matcher: [
    "/mobile/login",
    "/mobile/session",
    "/",
  ],
};
