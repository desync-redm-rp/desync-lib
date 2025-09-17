import React, { useEffect, useState } from 'react';
import '../styles/Progress.css';

const Circle = ({ size = 120, stroke = 10, progress = 0, label }) => {
  const radius = (size - stroke) / 2;
  const circumference = 2 * Math.PI * radius;
  const offset = circumference * (1 - progress / 100);

  return (
    <div className="ds-progress-circle-wrap">
      <svg
        className="ds-progress-circle"
        width={size}
        height={size}
        viewBox={`0 0 ${size} ${size}`}
      >
        <circle
          className="ds-circle-track"
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={stroke}
          fill="none"
        />
        <circle
          className="ds-circle-fill"
          cx={size / 2}
          cy={size / 2}
          r={radius}
          strokeWidth={stroke}
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
        />
      </svg>
      {label ? <div className="ds-circle-label">{label}</div> : null}
      <div className="ds-circle-percent">{Math.round(progress)}%</div>
    </div>
  );
};

const Bar = ({ progress = 0, label }) => {
  return (
    <div className="ds-progress-bar">
      {label ? <div className="ds-bar-label">{label}</div> : null}
      <div className="ds-bar-track">
        <div
          className="ds-bar-fill"
          style={{ width: `${Math.max(0, Math.min(100, progress))}%` }}
        />
      </div>
      {/* <div className="ds-bar-frame" aria-hidden="true" /> */}
    </div>
  );
};

const Progress = () => {
  const [visible, setVisible] = useState(false);
  const [type, setType] = useState(null); // 'bar' | 'circle'
  const [label, setLabel] = useState('');
  const [progress, setProgress] = useState(0);
  const [position, setPosition] = useState('middle'); // for circle: 'middle' | future positions

  useEffect(() => {
    const onMessage = (event) => {
      const data = event.data || {};
      switch (data.action) {
        case 'showProgressBar': {
          setType('bar');
          setLabel(data.label || 'Loading...');
          setProgress(0);
          setVisible(true);
          setPosition(data.position || 'middle');
          break;
        }
        case 'showProgressCircle': {
          setType('circle');
          setLabel(data.label || 'Loading...');
          setProgress(0);
          setPosition(data.position || 'middle');
          setVisible(true);
          break;
        }
        case 'updateProgress': {
          if (!visible) return;
          if (typeof data.progress === 'number') {
            setProgress(Math.max(0, Math.min(100, data.progress)));
          }
          if (typeof data.label === 'string') {
            setLabel(data.label);
          }
          break;
        }
        case 'hideProgress': {
          setVisible(false);
          setType(null);
          break;
        }
        default:
          break;
      }
    };

    window.addEventListener('message', onMessage);
    return () => window.removeEventListener('message', onMessage);
  }, [visible]);

  if (!visible || !type) return null;

  return (
    <div className={`ds-progress-root pos-${position}`}>
      <div className="ds-progress-container" role="dialog" aria-live="polite">
        {type === 'bar' ? (
          <Bar progress={progress} label={label} />
        ) : (
          <Circle progress={progress} label={label} />
        )}
      </div>
      {/* <div className="ds-progress-scrim" /> */}
    </div>
  );
};

export default Progress;