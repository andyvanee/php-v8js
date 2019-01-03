<?php

V8Js::registerExtension('environment', file_get_contents('environment.js'), [], true);

$v8 = new V8Js(
    "PHPCONTEXT",   //object_name
    [],             // variables
    [],             // extensions
    true            // report_uncaught_exceptions
);

$v8->setModuleLoader(function($m){
    $contents = file_get_contents($m);

    return $contents;
});

$v8->setModuleNormaliser(function($currentBase, $path){
    $currentBase = realpath($currentBase) . '/';

    $fullpath = realpath($currentBase . $path);

    if (!($fullpath && is_file($fullpath))) {
        throw new Exception(sprintf("Path not found: %s%s", $currentBase, $path));
    }

    return [
        pathinfo($fullpath, PATHINFO_DIRNAME),
        sprintf(
            "%s.%s",
            pathinfo($fullpath, PATHINFO_FILENAME),
            pathinfo($fullpath, PATHINFO_EXTENSION)
        )
    ];
});

$v8->console = function($t, $msg) {
    printf("%s: %s\n", $t, $msg);
};

$script = $v8->compileString(
    "require('index.js')",  // script
    'index.js'              // identifier
);

$v8->executeScript(
    $script,            // Script resource
    V8Js::FLAG_NONE,    // V8Js Flags
    30,                 // time_limit
    10 * 1024 * 1024    //memory_limit (bytes)
);
$exception = $v8->getPendingException();
