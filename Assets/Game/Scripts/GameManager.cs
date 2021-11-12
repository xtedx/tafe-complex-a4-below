using TeddyToolKit.Core;
using UnityEngine;

namespace Game.Scripts
{
    public class GameManager : MonoSingleton<GameManager>
    {
        [SerializeField] public LogToFile logToFile;
    }
}