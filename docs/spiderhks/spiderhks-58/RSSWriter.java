package alexa;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import org.apache.xerces.parsers.DOMParser;
import org.apache.xml.serialize.OutputFormat;
import org.apache.xml.serialize.XMLSerializer;

/** Writes an RSS file with properties specific to the Alexa feed
 *
 * @author Niall Kennedy
 * @version 1.0
 * @see http://blogs.law.harvard.edu/tech/rss
 */
public final class RSSWriter {
    /** absolute file name.  file named alexa.xml will be generated in user's home directory.
     */
    private final String filename;
    /** RFC 822 compliant time format.
     */
    private final SimpleDateFormat RFC822 =
        new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss z");
    /** time to live, set in minutes.
     * Set as a constant to 24 hours since Alexa uses daily stats  */
    private final int TTL = 1440;
    private Document doc;
    private final String title;
    private final String description;
    private final String link;
    private final String pubdate;

    /**
     *
     * @param title item title.  this is the RSS headline
     * @param description body of your message.
     * anything more than simple HTML may not be compatible with all aggregators
     * @param link full qualified hyperlink to the source page
     * @param pubdate date and time as published in the server's response
     */
    public RSSWriter(final String title, final String description, final String link, final String pubdate) {
        this.title = title;
        this.description = description;
        this.link = link;
        this.pubdate = pubdate;
        doc = null;
        StringBuffer filename = new StringBuffer(System.getProperty("user.home"));
        filename.append(File.separatorChar).append("alexa.xml");
        this.filename = filename.toString();
    }

    public void run() {
        File f = new File(filename);
        if (f.exists() && f.isFile()) {
            DOMParser parser = new DOMParser();
            try {
                parser.parse(filename);
                doc = parser.getDocument();
                Element last_update =
                    (Element) doc.getElementsByTagName("lastBuildDate").item(0);
                long last_update_millis =
                    RFC822.parse(last_update.getFirstChild().getNodeValue()).getTime();
                long pubdate_millis = RFC822.parse(pubdate).getTime();
                if ((pubdate_millis-last_update_millis)<(TTL*60*1000)) {
                    // add the item
                    Element channel = (Element) doc.getElementsByTagName("channel").item(0);
                    channel.appendChild(addItem());
                    Element new_update = doc.createElement("lastBuildDate");
                    new_update.appendChild(doc.createTextNode(RFC822.format(new Date())));
                    channel.replaceChild(new_update, last_update);
                }
            }
            catch (IOException e) {
                System.err.println("XML file import failed");
                e.printStackTrace();
            }
            catch (Exception e) {
                System.err.println("Parsing error");
                e.printStackTrace();
            }
        }
        else {
            try {
                doc = createBlankDocument();
            }
            catch (Exception e) {
                System.err.println("Parsing error in creation");
                e.printStackTrace();
            }
        }
        writeDocument();
    }

    /**
     * <p>Create a new DOM org.w3c.dom.Document object from the specified
     * object.</p>
     *
     * @return a new DOM Document.
     * @throws ParserConfigurationException if malformed doc
     */
    private Document createBlankDocument() throws ParserConfigurationException {
        // Use Sun's Java API for XML Parsing (JAXP) to create the
        // DOM Document
        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
        DocumentBuilder docBuilder = dbf.newDocumentBuilder();
        doc = docBuilder.newDocument();
        Element root = doc.createElement("rss");
        root.setAttribute("version", "2.0");
        Element channel = doc.createElement("channel");

        // essential elements
        Element title = doc.createElement("title");
        title.appendChild(doc.createTextNode("Alexa Traffic Reporting Tool"));
        // the link node is required, but there is no parameter-less page for Alexa
        // so the required link field is set to Alexa's home page
        Element link = doc.createElement("link");
        link.appendChild(doc.createTextNode("http://www.alexa.com"));
        Element description = doc.createElement("description");
        description.appendChild(doc.createTextNode("Traffic analysis data from Alexa's toolbar"));

        // optional elements
        Element language = doc.createElement("language");
        language.appendChild(doc.createTextNode("en-us"));
	Element webmaster = doc.createElement("webMaster");
	webmaster.appendChild(doc.createTextNode("oreilly@niallkennedy.com"));
        Element copyright = doc.createElement("copyright");
        copyright.appendChild(doc.createTextNode("1996-2003, Alexa Internet, Inc."));
        Element generator = doc.createElement("generator");
        generator.appendChild(doc.createTextNode("Niall Kennedy's RSS tool"));
	Element docs = doc.createElement("docs");
	docs.appendChild(doc.createTextNode("http://blogs.law.harvard.edu/tech/rss"));
        Element ttl = doc.createElement("ttl");
        ttl.appendChild(doc.createTextNode(Integer.toString(TTL)));
        Element builddate = doc.createElement("lastBuildDate");
        builddate.appendChild(doc.createTextNode(RFC822.format(new Date())));

        //add them all
        channel.appendChild(title);
        channel.appendChild(link);
        channel.appendChild(description);
        channel.appendChild(language);
	channel.appendChild(webmaster);
        channel.appendChild(copyright);
        channel.appendChild(generator);
	channel.appendChild(docs);
        channel.appendChild(ttl);
        channel.appendChild(builddate);
        channel.appendChild(addItem());
        root.appendChild(channel);
        doc.appendChild(root);
        return doc;
    }

    private Element addItem() {
        Element item = doc.createElement("item");
        Element etitle = doc.createElement("title");
        etitle.appendChild(doc.createTextNode(title));
        Element edesc = doc.createElement("description");
        edesc.appendChild(doc.createTextNode(description));
        Element elink = doc.createElement("link");
        elink.appendChild(doc.createTextNode(link));
        Element epub = doc.createElement("pubDate");
        epub.appendChild(doc.createTextNode(pubdate));

        item.appendChild(etitle);
        item.appendChild(edesc);
        item.appendChild(elink);
        item.appendChild(epub);

        return item;
    }

    private void writeDocument() {
        try {
            OutputFormat fmt = new OutputFormat(doc, "UTF-8", true);
            try {
                FileOutputStream fout = new FileOutputStream(filename);
                XMLSerializer serial = new XMLSerializer(fout, fmt);
                serial.serialize(doc.getDocumentElement());
                fout.close();
            }
            catch (IOException e) {
                System.out.println("File write failed");
                System.out.println(filename);
                e.printStackTrace();
            }
        }
        catch (Exception e) {
            System.out.println("Parse failed");
            e.printStackTrace();
        }
    }
}