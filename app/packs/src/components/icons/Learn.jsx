import React from "react";

const Bulb = props => (
  <svg
    width={props.size}
    height={props.size}
    viewBox="0 0 16 16"
    fill="none"
    xmlns="http://www.w3.org/2000/svg"
    className={props.className}
  >
    <path d="M15.3237 6.25293V9.25293" stroke="#1DB954" strokeLinecap="round" strokeLinejoin="round" />
    <path
      d="M12.3237 7.75293V11.5912C11.2331 12.6332 9.81286 13.2244 8.3312 13.2529C6.84557 13.222 5.42139 12.6314 4.32373 11.5912V7.75293"
      stroke="#1DB954"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
    <path
      d="M1.32373 6.25293L8.32373 9.25293L15.3237 6.25293L8.32373 3.25293L1.32373 6.25293Z"
      stroke="#1DB954"
      strokeLinecap="round"
      strokeLinejoin="round"
    />
  </svg>
);

export default Bulb;
