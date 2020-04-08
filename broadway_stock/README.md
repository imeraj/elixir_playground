# BroadwayStock

Pre-requisite: RabbitMQ must be installed and running.
Create a queue with below command - 

$rabbitmqadmin declare queue name=stock_queue durable=true    

To run the application:


$mix deps.get

$mix compile

$iex -S mix

iex(2)> $BroadwayStock.dispatch
