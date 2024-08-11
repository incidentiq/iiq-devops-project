import './css/App.css';
import Header from './components/header';
import TodoDisplay from './components/todoDisplay/todoDisplay';
import { useState } from 'react';

import 'bootstrap/dist/css/bootstrap.min.css';

function App() {
  const [serverUp, setServerUp] = useState(false)

  return (
    <div className="App">
      <Header serverUp={serverUp}/>
      <TodoDisplay serverUp={serverUp} setServerUp={setServerUp} />
    </div>
  );
}

export default App;
