using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PlayerLoop;
using Random = UnityEngine.Random;

public class FishMovement : MonoBehaviour
{
    [SerializeField] private Vector3 currentDirection;
    [SerializeField] private float fishSpeed = 3; 
    [SerializeField] private float distance = 10; 
    [SerializeField] private Vector3 currentDestination; 
    
    [SerializeField] private float turnSmoothTime = 0.5f;
    [SerializeField] private bool IsTurnSmooth;
    [SerializeField] private bool IsTimeDelta;
    [SerializeField] private float randomTurnFactorMin = 0.5f;
    [SerializeField] private float randomTurnFactorMax = 1;
    
    private float turnSmoothVelocity; // to hold temp value for angle smoothing

    Vector3 currentPosition;
    // Start is called before the first frame update
    void Start()
    {
        currentDirection = Vector3.left;
        currentPosition = transform.position;
        currentDestination = currentPosition + (currentDirection * distance);
    }

    // Update is called once per frame
    void Update()
    {
        moveTo(currentDestination);
        checkInput();
    }

    private void checkInput()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            getRandomBounceDirection();
        }
    }
    private void moveTo(Vector3 destination)
    {
        var timedelta = IsTimeDelta? Time.deltaTime: 1;
        
        transform.position = Vector3.MoveTowards(transform.position, destination, fishSpeed * timedelta);
    }
    
    /// <summary>
    /// make the character turn to a given direction
    /// </summary>
    /// <param name="direction"></param>
    /// <param name="isSmooth"></param>
    /// <returns></returns>
    private Vector3 turnTo(Vector3 direction, bool isSmooth)
    {
        //use atan x/y because we are facing positive y, standard atan y/x starts the angle 0deg from positive x if drawn on cartesian
        //atan is in rad, and convert to deg by multiplying
        //use z instead of y because we don't move up
        float turnTo = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg;
        //make character go forward to the angle where main camera is facing.
        //turnTo += Camera.main.transform.eulerAngles.y;

        if (isSmooth)
        {
            //smooth the angle to make it anime nicely
            turnTo =
                Mathf.SmoothDampAngle(transform.eulerAngles.y, turnTo, ref turnSmoothVelocity, turnSmoothTime);

        }
        //turn object offset by the turn in prefab, fish is facing right in prefab but angle 0 0 0, so offset by 90
        transform.rotation = Quaternion.Euler(0, turnTo+90, 0);
        
        //to move, now we need to convert the angle to a direction
        direction = Quaternion.Euler(0, turnTo, 0) * Vector3.forward;
        return direction.normalized;
    }

    /// <summary>
    /// reverse the direction and randomise by a few degrees
    /// </summary>
    /// <returns>the reversed direction</returns>
    private Vector3 getRandomBounceDirection()
    {
        var tempdest = -currentDestination;
        //var randomFactor = Vector3.zero;
        var x = Random.Range(randomTurnFactorMin, randomTurnFactorMax);
        var z = Random.Range(randomTurnFactorMin, randomTurnFactorMax);
        var randomFactor = new Vector3(x, 0, z);
        tempdest += randomFactor;
        tempdest = turnTo(tempdest, IsTurnSmooth);
        currentDirection = tempdest.normalized;
        currentDestination = currentPosition + (currentDirection * distance);
        return currentDirection;
    }

    private void OnTriggerEnter(Collider other)
    {
        //Debug.Log($"trigger hit a {other.tag}");
        //hits the lake wall
        if (other.CompareTag("Ground"))
        {
            getRandomBounceDirection();
        }
        //got caught by fishing line
        else if (other.CompareTag("Player"))
        {
            
        }
    }
}