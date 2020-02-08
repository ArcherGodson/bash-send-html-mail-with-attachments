#!/usr/bin/env bash

BOUNDARY=$(uuidgen -t)
FROM="$USER@$(hostname -f)"
BODY=""

while [ -n "$1" ]
do
case "$1" in
-f) # FROM
FROM="$2"
shift ;;

-t) # TO
TO="$2"
shift ;;

-s) # Subject
SUBJ="$2"
shift ;;

-p|-m) # Plain text | Message
BODY="$BODY
--$BOUNDARY
Content-Type: text/plain; charset=\"UTF-8\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

$2
"
shift ;;

--html) # HTML
BODY="$BODY
--$BOUNDARY
Content-type: text/html; charset=\"UTF-8\"

$2
"
shift ;;

-a|--attach) # Attachment
#Content-Type: text/csv;

BODY="$BODY
--$BOUNDARY
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$(basename $2)\"

$(base64 $2)
"
shift ;;

*) echo "$1 is not an option";;
exit 1
esac
shift
done

# SENDING
(
echo "From: $FROM
To: $TO
Subject: $SUBJ
MIME-Version: 1.0
Content-Type:multipart/mixed; boundary=\"$BOUNDARY\"

$BODY
--$BOUNDARY--";
) | sendmail -t
