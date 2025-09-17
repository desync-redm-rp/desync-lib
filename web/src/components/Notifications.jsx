import React, { useEffect, useMemo, useRef, useState } from 'react';
import '../styles/Notifications.css';

const POSITIONS = [
  'top-left',
  'top-right',
  'bottom-left',
  'bottom-right',
  'top',
  'bottom',
  'center'
];

const TYPE_CLASSES = {
  info: 'ds-notify--info',
  success: 'ds-notify--success',
  warning: 'ds-notify--warning',
  error: 'ds-notify--error'
};

const clampPosition = (pos) => (POSITIONS.includes(pos) ? pos : 'top-right');
const clampType = (t) => (TYPE_CLASSES[t] ? t : 'info');

const Notifications = () => {
  const [items, setItems] = useState([]);
  const timersRef = useRef(new Map());

  const addItem = (payload) => {
    const id = `${Date.now()}_${Math.random().toString(36).slice(2)}`;
    const type = clampType(payload.type || 'info');
    const title = payload.title || 'Notification';
    const description = payload.description || '';
    const duration = Number.isFinite(payload.duration) ? payload.duration : 5000;
    const position = clampPosition(payload.position || 'top-right');

    const item = { id, type, title, description, duration, position, createdAt: Date.now() };
    setItems((prev) => [...prev, item]);

    if (duration > 0) {
      const t = setTimeout(() => {
        removeItem(id);
      }, duration);
      timersRef.current.set(id, t);
    }
  };

  const removeItem = (id) => {
    setItems((prev) => prev.filter((n) => n.id !== id));
    const t = timersRef.current.get(id);
    if (t) {
      clearTimeout(t);
      timersRef.current.delete(id);
    }
  };

  useEffect(() => {
    const onMsg = (event) => {
      const data = event.data || {};
      if (data && data.action === 'showNotification') {
        addItem(data);
      }
    };
    window.addEventListener('message', onMsg);
    return () => {
      window.removeEventListener('message', onMsg);
      // cleanup timers
      timersRef.current.forEach((t) => clearTimeout(t));
      timersRef.current.clear();
    };
  }, []);

  const grouped = useMemo(() => {
    const groups = {};
    for (const p of POSITIONS) groups[p] = [];
    for (const n of items) groups[n.position]?.push(n);
    return groups;
  }, [items]);

  return (
    <>
      {POSITIONS.map((pos) => (
        <div key={pos} className={`ds-notify__stack ds-notify__stack--${pos}`} aria-live="polite" aria-relevant="additions">
          {grouped[pos].map((n) => (
            <div
              key={n.id}
              className={`ds-notify ${TYPE_CLASSES[n.type]}`}
              role="status"

            >
              <div className="ds-notify__frame">
                <div className="ds-notify__header">
                  <span className="ds-notify__badge" />
                  <span className="ds-notify__title">{n.title}</span>
                </div>
                {n.description ? <div className="ds-notify__body">{n.description}</div> : null}
                {n.duration > 0 ? (
                  <div className="ds-notify__timer" style={{ animationDuration: `${n.duration}ms` }} />
                ) : null}
              </div>
            </div>
          ))}
        </div>
      ))}
    </>
  );
};

export default Notifications;