package alexa;

import java.util.Collections;
import java.util.Hashtable;
import java.util.Map;

/** Parse a HTML <code>String</code> representing Alexa's traffic page
 * @author Niall Kennedy
 * @version 1.0
 */
public final class Parse {
    /** entire text to parse */
    private final String document;
    /** Company associated with the given domain */
    private String title;
    /** Parsed data goes here */
    private TrafficBean bean;
    /** speed up the String search by keeping track of the areas already combed over */
    private int place;

    /**
     * @param document source code to parse through
     */
    public Parse(final String document) {
        this.document = document;
        bean = new TrafficBean();
        title = null;
        place = 0;
    }

    public void run() {
        setTitle();
        System.out.println(title);
        bean.setSites(getSiteDomains());
        bean.setReachPerMillion(getTodayStat());
        bean.setReachRank(getTodayStat());
        bean.setViewsPerUser(getTodayStat());
        bean.setViewsRank(getTodayStat());
    }

    public String getTitle() {
        return title;
    }

    public TrafficBean getBean() {
        return bean;
    }

    /** Narrow down the length of a search string by defining identifying text occuring after the place index
     *
     * @param start_text
     * @param end_text
     * @return
     */
    private String snipIt(final String start_text, final String end_text) {
        String retval = null;
        try {
            int start_position = document.indexOf(start_text, place);
            if (start_position>=place) {
                int end_position = document.indexOf(end_text, start_position);
                if (end_position>start_position) {
                    retval = document.substring(start_position, end_position);
                    place = end_position;
                }
            }
        }
        catch (Exception e) {}
        return retval;
    }

    private void setTitle() {
        String start_tag = "<span class=\"title\">";
        String end_tag = "</span>";
        try {
            title = snipIt(start_tag, end_tag);
        }
        catch (Exception e) {}
        start_tag = null;
        end_tag = null;
    }

    private Map getSiteDomains() {
        Hashtable retval = new Hashtable();
        String snip = snipIt("<span class=\"titleO\">Where do people go on", "<hr size=\"1\">");
        // cycle through the list of subdomains
        for (int start = snip.indexOf("<li>");
             start>0;
             start = snip.indexOf("<li>", start)) {
            int end = snip.indexOf("~", start);
            if (end>0) {
                try {
                    String site = snip.substring(start+4, end).trim();
                    start = snip.indexOf("<b>", end);
                    if (start>0) {
                        // grab the number only
                        end = snip.indexOf("%</b>", start);
                        int pct = Integer.parseInt(snip.substring(start+3,end));
                        retval.put(new Integer(pct), site);
                    }
                    site = null;
                }
                catch (Exception e) {}
            }
        }
        snip = null;
        return Collections.unmodifiableMap(retval);
    }

    /** Each table is formatted the same, so we can reuse the same method on each.
     *
     * @return today's statistic (row 1, column 1)
     */
    private String getTodayStat() {
        String retval = null;
        String snip = snipIt("<table", "</table>");
        String tag = "</tr><tr><td class=\"bodyBold\" align=\"center\" bgcolor=\"#ffffff\">";
        try {
            int start = snip.indexOf(tag);
            if (start>0) {
                start += tag.length();
                int end = snip.indexOf("</td>", start);
                retval = snip.substring(start, end);
            }
        }
        catch (Exception e) {}
        snip = null;
        return retval;
    }
}