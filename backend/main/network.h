/*
 * Copyright (C) 2020 Rebecca Cran <rebecca@bsdio.com>.
 *
 */

void heimdall_setup_wifi(char *wifi_ssid, char *wifi_password);
void access_list_fetcher_thread(__attribute__((unused)) void *param);
void heimdall_setup_websocket(void);