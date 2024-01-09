using Godot;
using System;
using System.Diagnostics;

public partial class main : Control
{
	private Process _process = new Process();
	private int? _nextProgressUpdate = null;
	private ProgressBar _progressBar = null;
	
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		_process.StartInfo.FileName = "./long-running.sh";
		_process.StartInfo.RedirectStandardOutput = true;
		_progressBar = (ProgressBar)GetNode("ProgressBar");
		_process.OutputDataReceived += new DataReceivedEventHandler((sender, e) =>
		{
			if (!String.IsNullOrEmpty(e.Data))
			{
				_nextProgressUpdate = Int32.Parse(e.Data); 
				GD.Print(e.Data);
			}
		});

		
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (_nextProgressUpdate != null)
		{
			_progressBar.Value = _nextProgressUpdate.Value;
			_nextProgressUpdate = null;
		}
	}
	
	private void _on_start_pressed()
	{
		_process.Start();
		_process.BeginOutputReadLine();
	}

}
