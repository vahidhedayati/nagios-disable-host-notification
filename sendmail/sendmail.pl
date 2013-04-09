#!/usr/bin/perl

use MIME::Lite;
use Net::SMTP;

  $spath=$ARGV[0];
  $from=$ARGV[1];
  $to=$ARGV[2];
  $subject=$ARGV[3];
  $body=$ARGV[4];

  $msg = MIME::Lite->new(
        From    =>$from,
        To      =>$to,
        ##Cc      =>'some@other.com, some@more.com',
        Subject =>$subject,
        Type    =>'multipart/mixed'
    );

    $msg->attach(
  Type =>'text/html; charset="iso-8859-1"',
        Data     =>$body
    );
 $mail_host="localhost";
MIME::Lite->send('smtp', $mail_host, Timeout=>60);
$msg->send;
