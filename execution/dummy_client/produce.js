'use strict';

const rhea = require('rhea-promise');

const host = process.env.AMQP_HOST || 'localhost';
const port = parseInt(process.env.AMQP_PORT || '5672');
const username = process.env.AMQP_SENDER_USERNAME || '';
const password = process.env.AMQP_SENDER_PASSWORD || '';
const queue = process.env.AMQP_SEND_QUEUE || 'examples';

async function produce(payload) {
  const connectionOptions = {
    hostname: host,
    host: host,
    port: port,
    username: username,
    password: password,
    reconnect_limit: 100,
    transport: 'tls'
  };
  const connection = new rhea.Connection(connectionOptions);
  await connection.open();

  const senderOptions = {
    target: {
      address: queue,
    },
  };
  const sender = await connection.createAwaitableSender(senderOptions);
  const message = {
    body: JSON.stringify(payload)
  };

  const delivery = await sender.send(message);
  console.log('sending msg: ', message);
  console.log('[%s] await sendMessage -> Delivery id: %d, settled: %s', connection.id, delivery.id, delivery.settled);

  await sender.close();
  await connection.close();
}

module.exports = produce;