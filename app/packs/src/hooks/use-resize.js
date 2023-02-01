import { useEffect, useState, useCallback } from "react";

export const useResize = () => {
  const [windowSize, setWindowSize] = useState({
    width: undefined,
    height: undefined
  });
  const handleResize = useCallback(() => {
    const isDesktop = screen.width > 1000;
    setWindowSize({
      width: isDesktop ? window.innerWidth : screen.availWidth,
      height: isDesktop ? window.innerHeight : screen.height
    });
  }, []);
  useEffect(() => {
    if (typeof window === "undefined") return;
    handleResize();
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);
  return windowSize;
};
