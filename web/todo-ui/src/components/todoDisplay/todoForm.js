import { useState } from 'react';
import Form from 'react-bootstrap/Form';
import Button from 'react-bootstrap/Button';
import InputGroup from 'react-bootstrap/InputGroup';

function TodoForm ({addToList}) {
  const [todo, setTodo] = useState('')

  const addTodo = () => {
    addToList(todo)
    setTodo('')
  }

  return (
    <InputGroup>
      <Form.Label>New Item:</Form.Label>
      <Form.Control value={todo} onChange={e => setTodo(e.target.value)} type='text' placeholder='todo item text'></Form.Control>
      <Button variant='primary' disabled={todo === ''} onClick={addTodo}>Add</Button>
    </InputGroup>
  )
}
export default TodoForm