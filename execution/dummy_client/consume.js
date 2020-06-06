'use strict';

const rhea = require('rhea-promise');

const host = process.env.AMQP_HOST || 'localhost'
const port = parseInt(process.env.AMQP_PORT || '5672')
const username = process.env.AMQP_RECEIVER_USERNAME || '';
const password = process.env.AMQP_RECEIVER_PASSWORD || '';
const queue = process.env.AMQP_RECEIVE_QUEUE || 'examples';

function messageBody2String(message) {
  if (!message) return undefined;
  if (typeof message.body === 'string') return message.body;
  if (message && message.body.content) return message.body.content.toString('utf-8');
  if (message && Buffer.isBuffer(message.body)) return message.body.toString('utf8');
  return undefined;
}

async function consume(cb) {
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

  const receiverOptions = {
    source: {
      address: queue,
    },
    autoaccept: false,
  };

  const receiver = await connection.createReceiver(receiverOptions);
  receiver.on(rhea.ReceiverEvents.message, async (context) => {
    const msg = JSON.parse(messageBody2String(context.message));
    console.log('receiving msg', msg);
    cb(msg)
      .then(() => {
        context.delivery.accept();
      })
      .catch((err) => {
        console.log('error when sending cmdexe', err);
        context.delivery.release();
      })
      .finally(async () => {
        await receiver.close();
        await connection.close();
      });
  });
}

module.exports = consume;