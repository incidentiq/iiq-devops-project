import ListGroup from 'react-bootstrap/ListGroup';
import Container from 'react-bootstrap/Container';
import Row from 'react-bootstrap/Row';
import Col from 'react-bootstrap/Col';
import Form from 'react-bootstrap/Form'

function TodoItem ({item, markComplete}) {
  return (
    <ListGroup.Item key={item.id} id={item.id}>
      <Container>
        <Row>
          <Col>{item.name}</Col>
          <Col><Form.Check
            defaultChecked={item.isComplete}
            type='checkbox'
            id={item.name}
            onChange={e => markComplete(item.id, e.target.checked)}
          /></Col>
        </Row>
      </Container>
    </ListGroup.Item>
  )
}
export default TodoItem