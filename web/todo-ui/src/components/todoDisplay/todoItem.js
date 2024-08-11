import ListGroup from 'react-bootstrap/ListGroup';
import Col from 'react-bootstrap/esm/Col';
import Row from 'react-bootstrap/esm/Row';
import Form from 'react-bootstrap/Form';

function TodoItem ({item, markComplete}) {
  return (
    <ListGroup.Item variant={item.isComplete ? 'success' : ''} key={item.id} id={item.id}>
      <Row>
        <Col>
          {item.name}
        </Col>
        <Col>
          <Form.Check 
            type="switch" 
            defaultChecked={item.isComplete} 
            id={item.id} 
            onChange={e => markComplete(item.id, e.target.checked)}
          />
        </Col>
      </Row>
      </ListGroup.Item>
  )
}
export default TodoItem