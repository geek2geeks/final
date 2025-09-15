'use client';

import { useState, useEffect } from 'react';

interface IBackendStatus {
  isConnected: boolean;
  isLoading: boolean;
}

export default function Home() {
  const [backendStatus, setBackendStatus] = useState<IBackendStatus>({
    isConnected: false,
    isLoading: true,
  });

  useEffect(() => {
    const checkBackendHealth = async () => {
      try {
        const apiUrl =
          process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3001';
        const response = await fetch(`${apiUrl}/health`, {
          method: 'GET',
          headers: {
            'Content-Type': 'application/json',
          },
        });

        if (response.ok) {
          setBackendStatus({ isConnected: true, isLoading: false });
        } else {
          setBackendStatus({ isConnected: false, isLoading: false });
        }
      } catch (error) {
        setBackendStatus({ isConnected: false, isLoading: false });
      }
    };

    checkBackendHealth();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-b from-[#0f0f0f] to-[#1a1a1a] flex items-center justify-center p-4">
      <div className="max-w-4xl mx-auto text-center">
        <div className="mb-8">
          <h1 className="text-6xl md:text-8xl font-bold text-white mb-4 font-[family-name:var(--font-geist-sans)]">
            QuizzTok Live
          </h1>
          <p className="text-xl md:text-2xl text-gray-300 mb-8">
            Interactive Quiz Game Show for TikTok Streamers
          </p>
          <div className="inline-flex items-center gap-3 px-6 py-3 bg-black/20 rounded-full border border-gray-700">
            <div className="flex items-center gap-2">
              {backendStatus.isLoading ? (
                <>
                  <div className="w-3 h-3 bg-yellow-500 rounded-full animate-pulse"></div>
                  <span className="text-gray-300 text-sm">
                    Checking backend...
                  </span>
                </>
              ) : backendStatus.isConnected ? (
                <>
                  <div className="w-3 h-3 bg-green-500 rounded-full"></div>
                  <span className="text-gray-300 text-sm">
                    Backend Connected
                  </span>
                </>
              ) : (
                <>
                  <div className="w-3 h-3 bg-red-500 rounded-full"></div>
                  <span className="text-gray-300 text-sm">
                    Backend Disconnected
                  </span>
                </>
              )}
            </div>
          </div>
        </div>

        <div className="space-y-4">
          <h2 className="text-3xl md:text-4xl font-semibold text-[#FFD700] mb-6">
            Coming Soon
          </h2>
          <p className="text-lg text-gray-400 max-w-2xl mx-auto leading-relaxed">
            The ultimate live quiz experience is being crafted. Soon, streamers
            will be able to engage their TikTok audiences with dramatic quiz
            shows featuring golden reveals, animated leaderboards, and
            television-quality game show experiences.
          </p>
        </div>
      </div>
    </div>
  );
}
