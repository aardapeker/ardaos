import { useState } from 'react'
import { greeting } from './lib/greeting'

const CAT = String.raw`    /\_____/\
   /  o   o  \
  ( ==  ^  == )
   )         (
  (           )
 ( (  )   (  ) )
(__(__)___(__)__)`

export default function App() {
  const [pets, setPets] = useState(0)

  return (
    <main>
      <pre className="cat" aria-hidden="true">{CAT}</pre>
      <h1>__NAME__</h1>
      <p className="muted">{greeting(new Date())} · shipped with ArdaOS</p>
      <button onClick={() => setPets((n) => n + 1)}>
        pet Şemistan {pets > 0 && `(${pets})`}
      </button>
      <p className="hint">
        Edit <code>src/App.tsx</code>, save, and this page updates by itself.
      </p>
    </main>
  )
}
