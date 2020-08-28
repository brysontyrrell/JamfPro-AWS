DROP PROCEDURE IF EXISTS NEW_COMPUTER_EVENT;
DELIMITER ;;
CREATE PROCEDURE NEW_COMPUTER_EVENT(
	IN computer_id int(11),
	IN udid varchar(255),
	IN serial_number varchar(255),
    IN computer_name varchar(60),
    IN platform varchar(20),
    IN asset_tag varchar(40),
    IN mac_address varchar(20),
    IN last_ip  varchar(40),
    IN last_reported_ip varchar(40),
    IN jamf_version varchar(100),
    IN sip_status tinyint(1),
    IN gatekeeper_status tinyint(1),
    IN xprotect_version varchar(20)
) LANGUAGE SQL
BEGIN
  CALL mysql.lambda_async('arn:aws:lambda:REGION:ACCOUNT:function:NAME',
     CONCAT('{ "computer_id" : "', computer_id,
            '", "udid" : "', udid,
            '", "serial_number" : "', serial_number,
            '", "computer_name" : "', computer_name,
            '", "platform" : "', platform,
            '", "asset_tag" : "', asset_tag,
            '", "mac_address" : "', mac_address,
            '", "last_ip" : "', last_ip,
            '", "last_reported_ip" : "', last_reported_ip,
            '", "jamf_version" : "', jamf_version,
            '", "sip_status" : "', sip_status,
            '", "gatekeeper_status" : "', gatekeeper_status,
            '", "xprotect_version" : "', xprotect_version, '"}')
     );
END
;;
DELIMITER ;

DROP TRIGGER IF EXISTS NEW_COMPUTER_RECORD;

DELIMITER ;;
CREATE TRIGGER NEW_COMPUTER_RECORD
  AFTER INSERT ON computers_denormalized
  FOR EACH ROW
BEGIN
  SELECT
    New.computer_id,
    New.udid,
    New.serial_number,
    New.computer_name,
    New.platform,
    New.asset_tag,
    New.mac_address,
    New.last_ip,
    New.last_reported_ip,
    New.jamf_version,
    New.sip_status,
    New.gatekeeper_status,
    New.xprotect_version
  INTO
    @computer_id,
    @udid,
    @serial_number,
    @computer_name,
    @platform,
    @asset_tag,
    @mac_address,
    @last_ip,
    @last_reported_ip,
    @jamf_version,
    @sip_status,
    @gatekeeper_status,
    @xprotect_version;
  CALL NEW_COMPUTER_EVENT(
        @computer_id,
        @udid,
        @serial_number,
        @computer_name,
        @platform,
        @asset_tag,
        @mac_address,
        @last_ip,
        @last_reported_ip,
        @jamf_version,
        @sip_status,
        @gatekeeper_status,
        @xprotect_version
    );
END
;;
DELIMITER ;
