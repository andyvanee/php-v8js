const window = this;

const console =  {
    log: (message) => {
        PHPCONTEXT.console('Log', message)
    },
    warn: (message) => {
        PHPCONTEXT.console('Warn', message)
    },
    error: (message) => {
        PHPCONTEXT.console('Error', message)
    }
}
