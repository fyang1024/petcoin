module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    }
  },
  solc: {
    optimizer: {
      enabled: true,
      runs: 200
    }
  },
  authors: [
    "Fei Yang <fei.yang@3blox.fund>"
  ],
  license: "MIT"
};

