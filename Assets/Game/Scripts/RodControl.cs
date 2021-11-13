using System;
using System.Xml.Serialization;
using TeddyToolKit.Core;
using UnityEngine;

namespace Game.Scripts
{
    public class RodControl : MonoBehaviour
    {
        [SerializeField] public float speed = 100;
        [SerializeField] public Transform RodT;
        [SerializeField] public Transform LineT;
        
        private void Start()
        {
        }

        private void Update()
        {
            var direction = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
            //proceed only if there is input
            if (direction.magnitude < 0.1f)
            {
                return;
            }
            
            direction = direction * speed * Time.deltaTime;
            if (Input.GetKey(KeyCode.LeftShift))
            {
                MoveLine(direction);
            }
            else
            {
                MoveRod(direction);
            }
        }

        /// <summary>
        /// take the fish and put in pool with score
        /// </summary>
        /// <param name="fishGameObject"></param>
        /// <param name="isScore"></param>
        public void MoveLine(Vector3 direction)
        {
            //x on x left right
            //z on z forward back
            LineT.Rotate(direction.x,0,direction.z);
        }

        /// <summary>
        /// take all the fish in the lake and put in pool without scoring
        /// </summary>
        public void MoveRod(Vector3 direction)
        {
            //x on y left right
            //z on z up down
            RodT.Rotate(0, direction.x,direction.z);
        }
    }
}