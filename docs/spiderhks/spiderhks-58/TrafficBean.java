package alexa;

import java.text.NumberFormat;
import java.util.Map;

/** Standard entity bean style.  Good for holding related data
 *
 * @author Niall Kennedy
 * @version 1.0
 */
public final class TrafficBean {
    /** Adds commas to large numbers.
     */
    public final NumberFormat NUMBER_PURIFY = NumberFormat.getInstance();
    /** subdomains. key of percentage expressed as an <code>Integer</code> and
     *  value of property name */
    private Map sites;
    /** The percentage of one million Internet users who visit the given site */
    private int reach_per_million;
    /** A ranking of all sites based solely on their reach */
    private int reach_rank;
    /** The number of pages viewed by Alexa Toolbar users.
     * Multiple page views of the same page made by the same user on the same day are counted only once.*/
    private int views_per_user;
    /** a ranking of all sites based solely on the total number of page views (not page views per user) */
    private int views_rank;

    /** Initialize all variables
     */
    public TrafficBean() {
        clearAll();
    }

    /** clear all class variables
     */
    public void clearAll() {
        sites = null;
        reach_per_million = 0;
        reach_rank = 0;
        views_per_user = 0;
        views_rank = 0;
    }

    public Map getSites() {
        return sites;
    }

    public void setSites(final Map val) {
        this.sites = val;
    }

    public int getReachPerMillion() {
        return reach_per_million;
    }

    public void setReachPerMillion(final String val) {
        reach_per_million = stringToInt(val);
    }

    public int getReachRank() {
        return reach_rank;
    }

    public void setReachRank(final String val) {
        reach_rank = stringToInt(val);
    }

    public int getViewsPerUser() {
        return views_per_user;
    }

    public void setViewsPerUser(final String val) {
        views_per_user = stringToInt(val);
    }

    public int getViewsRank() {
        return views_rank;
    }

    public void setViewsRank(final String val) {
        views_rank = stringToInt(val);
    }

    /** Remove common number markups such as a comma and convert the result
     * to an <code>int</code> data type
     * @param val String value in need of conversion
     * @return value of the passed <code>String</code>, or zero if no value found.
     * Decimals are dropped, not rounded.
     */
    private int stringToInt(final String val) {
        int retval = 0;
        try {
            retval = NUMBER_PURIFY.parse(val).intValue();
        }
        catch (Exception e) {}
        return retval;
    }
}