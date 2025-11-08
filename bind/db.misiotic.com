$TTL 1D
@   IN  SOA dns.misiotic.com. admin.misiotic.com. (
        2025110701 ; Serial (AAAAMMDDnn)
        3600       ; Refresh
        900        ; Retry
        604800     ; Expire
        86400 )    ; Minimum

; ----- Nameserver -----
@           IN  NS  dns.misiotic.com.

; ----- Registros A -----
dns         IN  A   10.1.80.6
www         IN  A   10.1.80.2
mail        IN  A   10.1.80.4
file        IN  A   10.1.80.5
fw          IN  A   10.1.80.1
proxy       IN  A   10.1.80.3

; Alias
ftp         IN  CNAME file
smtp        IN  CNAME mail
gateway     IN  CNAME fw

; MX principal
@           IN  MX 10 mail.misiotic.com.
