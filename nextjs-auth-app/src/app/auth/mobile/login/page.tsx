"use client";

import React, { Suspense, useEffect } from 'react';
import { signIn } from 'next-auth/react';
import { useSearchParams } from 'next/navigation';

const SignInAuthPageContent: React.FC = () => {
  const searchParams = useSearchParams();
  const provider = searchParams.get("provider");
  
  useEffect(() => {
    const getAuthPage = async () => {
      await signIn(`${provider}`, { callbackUrl: '/auth/mobile/session' });
    };

    getAuthPage();
  }, [provider]);

  if (!provider) {
    return <div>Add a provider to the parameters (google, facebook, or apple.......)</div>;
  }

  return (
    <div className="flex items-center justify-center h-screen bg-gray-100">
      <div className="w-9 h-9 border-4 border-gray-300 border-t-4 border-t-[#9c27b0] rounded-full animate-spin"></div>
    </div>
  );
};

const SignInAuthPage: React.FC = () => {
  return (
    <Suspense>
      <SignInAuthPageContent />
    </Suspense>
  );
};

export default SignInAuthPage;