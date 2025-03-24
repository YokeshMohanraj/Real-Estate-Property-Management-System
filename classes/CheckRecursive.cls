/***************************************************************************************************************************************
* Name           :  CheckRecursive
* Description    :  Reusable class to check if the method is called recursively, used mostly in triggers.
* @author        :  Yokesh Mohanraj
* @date          :  03/22/2025
****************************************************************************************************************************************/

public class CheckRecursive {
    public static Boolean  runOnce(){
        Integer i = 0;
        if(i<1){
            i=i+1;
            return true;
        }
        else{
            return false;
        }
    }
}