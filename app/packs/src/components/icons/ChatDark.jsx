import React from "react";
import { darkPrimary, darkSurfaceHover } from "src/utils/colors";

const ChatDark = ({ height = "32", width = "40" }) => (
  <svg xmlns="http://www.w3.org/2000/svg" width={width} height={height} viewBox="0 0 32 32" fill="none">
    <circle cx="16" cy="16" r="16" fill={darkSurfaceHover} />
    <path
      d="M8.93332 10.4953C8.82923 10.3091 8.78744 10.0944 8.81405 9.88276C8.84066 9.67107 8.93428 9.47345 9.08122 9.31876C9.22816 9.16407 9.42072 9.06044 9.63076 9.023C9.8408 8.98556 10.0573 9.01628 10.2487 9.11067L22.9247 15.55C23.0069 15.5918 23.076 15.6556 23.1242 15.7343C23.1724 15.8129 23.198 15.9034 23.198 15.9957C23.198 16.0879 23.1724 16.1784 23.1242 16.2571C23.076 16.3357 23.0069 16.3995 22.9247 16.4413L10.2487 22.8893C10.0573 22.9837 9.8408 23.0144 9.63076 22.977C9.42072 22.9396 9.22816 22.8359 9.08122 22.6812C8.93428 22.5266 8.84066 22.3289 8.81405 22.1172C8.78744 21.9056 8.82923 21.6909 8.93332 21.5047L12.3053 15.9953L8.93332 10.4953Z"
      stroke={darkPrimary}
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    <path d="M23.198 15.9953H12.302" stroke={darkPrimary} strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

export default ChatDark;
