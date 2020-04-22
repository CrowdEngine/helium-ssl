const now = () => {
  const time = new Date();
  const year = time.getFullYear();
  const month = (time.getMonth() + 1) > 9 ? (time.getMonth() + 1) : ('0' + (time.getMonth() + 1));
  const date = time.getDate() > 9 ? time.getDate() : '0' + time.getDate();
  const hour = time.getHours() > 9 ? time.getHours() : '0' + time.getHours();
  const minute = time.getMinutes() > 9 ? time.getMinutes() : '0' + time.getMinutes();
  const second = time.getSeconds() > 9 ? time.getSeconds() : '0' + time.getSeconds();
  return `${year}-${month}-${date} ${hour}:${minute}:${second}`;
};
const normalize = (msg) => typeof(msg) == 'object' ? JSON.stringify(msg) : msg;
const log = (msg) => console.log(`[${now()}] - ${normalize(msg)}`);
const lerror = (msg) => console.error(`[${now()}] - ${normalize(msg)}`);

module.exports = {
  lerror,
  log
};