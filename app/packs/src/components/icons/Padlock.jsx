import React from "react";
import Icon from "src/components/design_system/icon";

const Padlock = props => (
  <Icon
    path="M12.5 6.5H3.5C2.94772 6.5 2.5 6.94772 2.5 7.5V14.5C2.5 15.0523 2.94772 15.5 3.5 15.5H12.5C13.0523 15.5 13.5 15.0523 13.5 14.5V7.5C13.5 6.94772 13.0523 6.5 12.5 6.5Z M4.5 6.5V4C4.5 3.07174 4.86875 2.1815 5.52513 1.52513C6.1815 0.868749 7.07174 0.5 8 0.5C8.92826 0.5 9.8185 0.868749 10.4749 1.52513C11.1313 2.1815 11.5 3.07174 11.5 4V6.5 M8 10.5C7.95055 10.5 7.90222 10.5147 7.86111 10.5421C7.82 10.5696 7.78795 10.6086 7.76903 10.6543C7.75011 10.7 7.74516 10.7503 7.7548 10.7988C7.76445 10.8473 7.78826 10.8918 7.82322 10.9268C7.85819 10.9617 7.90273 10.9855 7.95123 10.9952C7.99972 11.0048 8.04999 10.9999 8.09567 10.981C8.14135 10.962 8.1804 10.93 8.20787 10.8889C8.23534 10.8478 8.25 10.7994 8.25 10.75C8.25009 10.7171 8.24368 10.6846 8.23115 10.6542C8.21862 10.6239 8.2002 10.5963 8.17697 10.573C8.15374 10.5498 8.12615 10.5314 8.09577 10.5189C8.0654 10.5063 8.03286 10.4999 8 10.5V10.5Z"
    {...props}
  />
);

export default Padlock;
