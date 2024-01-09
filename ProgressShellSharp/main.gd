extends Control

var log_thread: Thread
var shell_thread: Thread
var mutex: Mutex
var next_progress_bar_value = null
var directory = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	log_thread = Thread.new()
	shell_thread = Thread.new()
	mutex = Mutex.new()
	
	var output = []
	OS.execute("pwd", [], output)
	directory = output[0].replace("\n", "")
	
func _start_pressed():
	shell_thread.start(_shell_thread_function)
	log_thread.start(_log_thread_function)

func _log_thread_function():
	while (!FileAccess.file_exists("%s/tmp-file" % directory)):
		continue
	var file = FileAccess.open("%s/tmp-file" % directory, FileAccess.READ)
	while (shell_thread.is_alive()):
		OS.delay_msec(1000)
		print("Still alive")
		var content = file.get_as_text()
		print(int(content))
		mutex.lock()
		next_progress_bar_value = int(content)
		mutex.unlock()
		
	print("Dead")
	
func _shell_thread_function():
	OS.execute("%s/long-running.sh" % directory, [])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (next_progress_bar_value != null):
		mutex.lock()
		$ProgressBar.value = next_progress_bar_value
		next_progress_bar_value = null
		mutex.unlock()
