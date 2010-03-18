package alexa;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.IOException;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.HttpURLConnection;

/** Opens a HTTP connection and pulls the source code of Alexa's traffic detail site
 *
 * @author Niall Kennedy
 * @version 1.0
 */
public final class Website {
    private final String BASEURL="http://www.alexa.com/data/details/traffic_details?url=";
    private final String url_location;
    private String header_date;

    /**
     *
     * @param url parameter URL of a Web domain.  ex: http://domain.tld
     */
    public Website(final String url) {
        this.url_location =  BASEURL + url;
    }

    public String getURLLocation() {
        return url_location;
    }

    public String getHeaderDate() {
        return header_date;
    }

    /** Retrieves the full source of the requested page.
     * Sets header_date to date supplied by the server
     *
     * @return full source code of the file located at url_location
     */
    public String retrieveSource() {
        StringBuffer source = new StringBuffer();
        try {
            URL u = new URL(getURLLocation());
            HttpURLConnection connect = (HttpURLConnection) u.openConnection();
            // Masquerade as a common Web browser request
            connect.setRequestProperty("User-Agent", "Mozilla/5.0");
            connect.setUseCaches(false);
            header_date = connect.getHeaderField("Date");
            BufferedReader html = new BufferedReader(new InputStreamReader(connect.getInputStream()));
            String line = null;
            while ((line=html.readLine())!=null) {
                source.append(line);
            }
            line = null;
            html.close();
            html = null;
            u = null;
            connect.disconnect();
            connect = null;
        }
        catch (MalformedURLException e) {
            source = null;
        }
        catch (IOException e) {
            System.err.println("I/O Error");
            System.err.println(url_location);
            e.printStackTrace();
        }
        if (source==null) {
            return null;
        }
        else {
            return source.toString();
        }
    }

    /** Given the complete source, return only the HTML body
     *
     * @param fullpage complete source code of the provided destination
     * @return body of the HTML page, or null if lowercase body tags not found
     */
    public static String bodyFilter(final String fullpage) {
        if (fullpage==null) {
            return null;
        }
        String retval = null;
        String start_tag = "<body";
        String end_tag = "body>";
        int start = fullpage.indexOf(start_tag);
        int end = fullpage.lastIndexOf(end_tag);
        if (start>=0 && end>0) {
            retval = fullpage.substring(start, end+end_tag.length());
        }
        return retval;
    }
}