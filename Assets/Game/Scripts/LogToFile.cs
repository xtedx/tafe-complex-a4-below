using System;
using System.IO;
using UnityEngine;

/// <summary>
/// utility class to allow us output log entries to a file
/// </summary>
public class LogToFile : MonoBehaviour
{
    [SerializeField] private string filename;

    #region events management
    private void OnEnable()
    {
        Application.logMessageReceived += LogFull;
    }

    private void OnDisable()
    {
        Application.logMessageReceived -= LogFull;
    }
    #endregion

    /// <summary>
    /// shortcut for the LogFull
    /// </summary>
    /// <param name="text"></param>
    public void Log(string text)
    {
        LogFull(text, "", LogType.Log);
    }
    
    /// <summary>
    /// the main function to log
    /// </summary>
    /// <param name="text"></param>
    /// <param name="stackTrace"></param>
    /// <param name="type"></param>
    /// <param name="filename"></param>
    public void LogFull(string text, string stackTrace, LogType type)
    {
        //check if file exists or create default file
        if (filename == "" || !File.Exists(filename))
        {
            var log_path = $"{getDesktopPath()}{Path.DirectorySeparatorChar}Unity_Logs";
            System.IO.Directory.CreateDirectory(log_path);
            var dateString = DateTime.Now.ToString("yyyy-MM-dd_hh-mm-ss");
            filename = $"{log_path}{Path.DirectorySeparatorChar}{dateString}.log";
            Debug.Log($"file '{filename}' not found, using default file");
        }
        //try to execute the IO operation
        try
        {
            System.IO.File.AppendAllText(filename, $"{text}{Environment.NewLine}");
        }
        catch (IOException e)
        {
            //log to console instead if there is some io problem
            Debug.LogError($"Fatal IO Error: {e}");
            Debug.LogError(text);
        }
    }

    /// <summary>
    /// returns the path of special folder Desktop
    /// </summary>
    /// <returns></returns>
    private string getDesktopPath()
    {
        return System.Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
    }
}