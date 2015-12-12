<?php
require_once 'config/config.php';
require_once 'libs/XeroOAuth-PHP/lib/XeroOAuth.php';

switch($_GET['method']) {
    case 'makepurchase':
        /* This will connect to a SQLite Database, insert a row with datetime of
        purchase with value. Then make a request to Xero.

        Upon success, it will return a HTTP 201 code along with whatever content
        is posted to it. On Failure it wil return a HTTP 500 with an error message
        */

        break;

    default:
        http_response_code(501);
        echo 'Not Implemented';
        break;
}
