package alexa;

import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Map;

/** Main class of the alexa package.  Gathers data and composes the message.
 * @author Niall Kennedy
 * @version 1.0
 */
public final class Report {
    private final DecimalFormat NUMBER_PRETTY = new DecimalFormat("#,##0");
    private final String url;
    private String generated;
    private String name;
    private StringBuffer body;
    private TrafficBean bean;

    public static void main(String [] args) {
        String [] sites = null;
        if (args.length>0) {
	    sites = args;
        }
        else {
            // use a default set of sites
	    sites = {"oreilly.com", "manning.com",
	             "osborne.com", "wrox.com"};
	}
	for (int i=0; i<sites.length; ++i) {
	    Report r = new Report("http://" + sites[i]);
	    r.collectData();
	    r.writeData();
            r = null;
        }
        sites = null;
    }

    /** It all starts here.
     *
     * @param url fully qualified Web address (example: http://www.google.com)
     */
    public Report(final String url) {
        this.url = url.toLowerCase().trim();
        System.out.println("Processing " + url);
        name = url;
        body = new StringBuffer();
        bean = new TrafficBean();
        generated = null;
    }

    /** Gather data from various classes and compose the body of the message
     */
    public void collectData() {
        Website web = new Website(url);
        Parse p = new Parse(Website.bodyFilter(web.retrieveSource()));
        generated = web.getHeaderDate();
        p.run();
        name = p.getTitle();
        bean = p.getBean();
        body.append("<h1>Alexa Traffic Report for:</h1>");
        body.append("<p>");
        if (name!=null && !name.equalsIgnoreCase(url)) {
            body.append("<strong>");
            body.append(name).append("</strong><br />");
        }
        body.append("<a href=\"");
        body.append(url).append("\">");
        body.append(url).append("</a></p><br />");
        body.append(showDestinations());
        body.append(showReach());
        body.append(showViews());
        p = null;
        web = null;
    }

    /** Writes data to RSS file
     */
    public void writeData() {
        RSSWriter rss = new RSSWriter(name, body.toString(), url, generated);
        rss.run();
        rss = null;
    }

    /** Show the top subdomains in order of decending popularity
     *
     * @return a paragraph detailing subdomain activity, or an empty <code>String</code> if none exist
     */
    private String showDestinations() {
        StringBuffer retval = new StringBuffer();
        Map sites = bean.getSites();
        if (sites!=null && sites.size()>0) {
            retval.append("<a href=\"http://pages.alexa.com/prod_serv/traffic_learn_more.html#web_hosts\"><font size=\"+1\">Most Popular Subdomains</font></a><br />");
            ArrayList keys = new ArrayList(sites.keySet());
            Collections.sort(keys);
            for(int i=keys.size()-1; i>0; --i) {
                int pct = Integer.parseInt(keys.get(i).toString());
                String site = sites.get(new Integer(pct)).toString();
                retval.append(pct);
                retval.append(" %&nbsp;&nbsp;--&nbsp;&nbsp;");
                if (site.equalsIgnoreCase("Other websites")) {
                    retval.append(site);
                }
                else {
                    retval.append("<a href=\"http://");
                    retval.append(site);
                    retval.append("\">");
                    retval.append(site);
                    retval.append("</a>");
                }
                retval.append("<br />");
                site = null;
            }
            keys = null;
        }
        sites = null;
        retval.append("<br />");
        return retval.toString();
    }

    /** Show the total reach of the domain
     *
     * @return paragraph detailing reach per million and database rank,
     * or empty <code>String if no data available
     */
    private String showReach() {
        StringBuffer retval = new StringBuffer();
        int reach = bean.getReachPerMillion();
        int reach_rank = bean.getReachRank();
        if (reach>0 || reach_rank>0) {
            retval.append("<a name=\"Learn More\" href=\"http://pages.alexa.com/prod_serv/traffic_learn_more.html#reach\"><font size=\"+1\">Domain Reach</font></a><br />Reach per million : ");
            retval.append(NUMBER_PRETTY.format(reach));
            retval.append("<br />");
            retval.append("Reach Rank&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ");
            retval.append(NUMBER_PRETTY.format(reach_rank));
            retval.append("<br /><br />");
        }
        return retval.toString();
    }

    /** <p>Paragraph detailing how many pages an average viewer navigates to
     *  within the domain and how total views compare to the entire database of domains.</p>
     *
     * @return paragraph detailing a site's popularity and depth
     */
    private String showViews() {
        StringBuffer retval = new StringBuffer();
        int views = bean.getViewsPerUser();
        int views_rank = bean.getViewsRank();
        if (views>0 || views_rank>0) {
            retval.append("<a name=\"Learn More\" href=\"http://pages.alexa.com/prod_serv/traffic_learn_more.html#page_views\"><font size=\"+1\">Page Views</font></a><br />Page Views Per User : ");
            retval.append(NUMBER_PRETTY.format(views));
            retval.append("<br />Page Views Rank&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;: ");
            retval.append(NUMBER_PRETTY.format(views_rank));
        }
        return retval.toString();
    }
}