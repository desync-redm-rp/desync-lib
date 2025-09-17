import React, { useState, useEffect } from 'react';
import './App.css';
import Notifications from './components/Notifications';
import Progress from './components/Progress';

const App = () => {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    // Listen for messages from the client
    const handleMessage = (event) => {
      const data = event.data;
      if (data.type === 'showUI') {
        setIsVisible(true);
      } else if (data.type === 'hideUI') {
        setIsVisible(false);
      }
      // Notifications are handled inside the Notifications component via action === 'showNotification'
    };

    window.addEventListener('message', handleMessage);
    
    return () => {
      window.removeEventListener('message', handleMessage);
    };
  }, []);

  return (
    <>
      {/* Always-mounted UI modules */}
      <Notifications />
      <Progress />

      {/* Keep existing demo UI behavior */}
      {!isVisible ? null : (
        <div className="app">
          <div className="hello-world">
            <h1>Hello World</h1>
            <p>RedM React UI is working!</p>
            <button 
              onClick={() => {
                fetch('https://desync-lib/closeUI', {
                  method: 'POST',
                  headers: {
                    'Content-Type': 'application/json',
                  },
                  body: JSON.stringify({})
                });
              }}
              className="close-button"
            >
              Close
            </button>
          </div>
        </div>
      )}
    </>
  );
};

export default App;