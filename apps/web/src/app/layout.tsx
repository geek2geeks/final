import type { Metadata } from 'next';
import localFont from 'next/font/local';
import './globals.css';

const geistSans = localFont({
  src: './fonts/GeistVF.woff',
  variable: '--font-geist-sans',
  weight: '100 900',
});
const geistMono = localFont({
  src: './fonts/GeistMonoVF.woff',
  variable: '--font-geist-mono',
  weight: '100 900',
});

export const metadata: Metadata = {
  title: 'QuizzTok Live',
  description: 'Interactive live quiz game show for TikTok streamers',
  openGraph: {
    title: 'QuizzTok Live',
    description: 'Interactive live quiz game show for TikTok streamers',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'QuizzTok Live',
    description: 'Interactive live quiz game show for TikTok streamers',
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body
        className={`${geistSans.variable} ${geistMono.variable} antialiased`}
      >
        {children}
      </body>
    </html>
  );
}
