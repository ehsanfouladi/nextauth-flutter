'use client';

import { useSession } from 'next-auth/react';
import { useEffect, useState } from 'react';

interface ClientSessionPageProps {
  sessionToken: string | null;
}

const ClientSessionPage: React.FC<ClientSessionPageProps> = ({ sessionToken }) => {
  const [sessionSent, setSessionSent] = useState(false);
  const { data: session, status } = useSession();

  useEffect(() => {
    if (status === 'authenticated' && sessionToken && !sessionSent) {
      if (window.flutter_inappwebview) {
        let sessionData = {
          session: session,
          sessionToken: sessionToken,
        }
        window.flutter_inappwebview.callHandler('mobileSessionHandler', sessionData);
        setSessionSent(true);
      }
    }
  }, [status, sessionToken, sessionSent, session]);

  return (
    <div className="flex items-center justify-center h-screen bg-gray-100">
      <div className="w-9 h-9 border-4 border-gray-300 border-t-4 border-t-[#9c27b0] rounded-full animate-spin"></div>
    </div>
  );
};

export default ClientSessionPage;
