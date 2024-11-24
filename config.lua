return {
	baseUrl = "https://apibay.org/q.php",
	clipboard_command_x11 = "echo -n %q | xclip -selection clipboard",
	clipboard_command_wayland = "echo -n %q | wl-copy",
	trackers_url = "https://cdn.jsdelivr.net/gh/ngosang/trackerslist@master/trackers_best.txt",
	torrent_list = {
		reverse = false, -- reverse the order of the torrent list
	},
}
