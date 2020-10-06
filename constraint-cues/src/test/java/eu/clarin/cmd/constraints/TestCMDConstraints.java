/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package eu.clarin.cmd.constraints;

import java.io.IOException;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.URL;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.s9api.DOMDestination;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XPathCompiler;
import net.sf.saxon.s9api.XPathExecutable;
import net.sf.saxon.s9api.XPathSelector;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XdmNode;
import net.sf.saxon.s9api.XdmValue;
import net.sf.saxon.s9api.XsltTransformer;
import nl.mpi.tla.schemanon.Message;
import nl.mpi.tla.schemanon.SaxonUtils;
import nl.mpi.tla.schemanon.SchemAnon;
import org.junit.*;

import static org.junit.Assert.*;
import org.w3c.dom.Document;

/**
 *
 * @author menwin
 */
public class TestCMDConstraints {

    XsltTransformer cuesCMDSpec = null;
    SchemAnon validateCMDrecord = null;

    @Before
    public void setUp() {
        try {
            cuesCMDSpec = SaxonUtils.buildTransformer(CMDConstraints.class.getResource("/cue-constraints.xsl")).load();
        } catch(Exception e) {
            System.err.println("!ERR: couldn't setup the testing environment!");
            System.err.println(""+e);
            e.printStackTrace(System.err);
        }
    }

    @After
    public void tearDown() {
    }

    protected Document transform(XsltTransformer trans,Source src,Map<String,XdmValue> params) throws Exception {
        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();
            DOMDestination dest = new DOMDestination(doc);
            trans.setSource(src);
            trans.setDestination(dest);
            // always set cmd-toolkit to the current working directory, which is expected to be where pom.xml lives
            trans.setParameter(new QName("cmd-toolkit"),new XdmAtomicValue(Paths.get("").toAbsolutePath().toString()+"/src/main/resources/toolkit"));
            if (params!=null)
                for(String param:params.keySet())
                    trans.setParameter(new QName(param),params.get(param));
            trans.transform();
            return doc;
        } catch (Exception e) {
            System.out.println("!ERR: failed transform: "+e);
            e.printStackTrace(System.out);
            throw e;
        }
    }

    protected Document transform(XsltTransformer trans,Source src) throws Exception {
        return transform(trans,src,null);
    }

    protected boolean xPathCompiler(Document doc, String xpath, String profileId) throws Exception {
      XPathCompiler xpc   = SaxonUtils.getProcessor().newXPathCompiler();

      xpc.declareNamespace("xs","http://www.w3.org/2001/XMLSchema");
      xpc.declareNamespace("cmd","http://www.clarin.eu/cmd/1");
      if(profileId != null) xpc.declareNamespace("cmdp", "http://www.clarin.eu/cmd/1/profiles/" + profileId);

      XPathExecutable xpe = xpc.compile(xpath);
      XPathSelector xps   = xpe.load();
      xps.setContextItem(SaxonUtils.getProcessor().newDocumentBuilder().wrap(doc));

      return xps.effectiveBooleanValue();
    }

    protected boolean xpath(Document doc, String xpath, String profileId) throws Exception {
      return xPathCompiler(doc, xpath, profileId);
    }

    protected boolean xpath(Document doc,String xpath) throws Exception {
      return xPathCompiler(doc, xpath, null);
    }

    protected void printMessages(SchemAnon anon) throws Exception {
        for (Message msg : anon.getMessages()) {
            System.out.println("" + (msg.isError() ? "ERROR" : "WARNING") + (msg.getLocation() != null ? " at " + msg.getLocation() : ""));
            System.out.println("  " + msg.getText());
        }
    }

    protected int countErrors(SchemAnon anon) throws Exception {
        int cnt = 0;
        for (Message msg : anon.getMessages())
            cnt += (msg.isError()?1:0);
        return cnt;
    }

    protected int countWarnings(SchemAnon anon) throws Exception {
        int cnt = 0;
        for (Message msg : anon.getMessages())
            cnt += (!msg.isError()?1:0);
        return cnt;
    }
    
    public static void printDocument(Document doc, OutputStream out) throws IOException, TransformerException {
        TransformerFactory tf = TransformerFactory.newInstance();
        Transformer transformer = tf.newTransformer();
        transformer.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "no");
        transformer.setOutputProperty(OutputKeys.METHOD, "xml");
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");
        transformer.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
        transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "4");

        transformer.transform(new DOMSource(doc), new StreamResult(new OutputStreamWriter(out, "UTF-8")));
    }

    protected SchemAnon compileConstraints(String spec) throws Exception {
        System.out.println("compile constraints["+spec+"]");
        Document rules =  transform(cuesCMDSpec,new javax.xml.transform.stream.StreamSource(new java.io.File(TestCMDConstraints.class.getResource(spec).toURI())));
        return new SchemAnon(new DOMSource(rules));
    }

    protected boolean validateRecord(SchemAnon tron, String rec) throws Exception {
        System.out.println("validate record["+rec+"]");
        boolean res = tron.validateSchematron(new javax.xml.transform.stream.StreamSource(new java.io.File(TestCMDConstraints.class.getResource(rec).toURI())));
        System.out.println("> "+(res?"":"IN")+"VALID");
        //printMessages(tron);
        return res;
    }

    @Test
    public void testInclusiveOr() throws Exception {
        System.out.println("* BEGIN: inclusive-or");

        SchemAnon tron = compileConstraints("/TestConstraints-inclusive-or.xml");

        System.out.println("- RECORD:hello (invalid)");

        assertFalse(validateRecord(tron, "/test-hello.xml"));

        System.out.println("- RECORD:hello eric (valid)");

        assertTrue(validateRecord(tron, "/test-hello_eric.xml"));

        System.out.println("- RECORD:hello clarin (valid)");

        assertTrue(validateRecord(tron, "/test-hello_clarin.xml"));

        System.out.println("- RECORD:hello clarin eric (valid)");

        assertTrue(validateRecord(tron, "/test-hello_clarin_eric.xml"));

        System.out.println("*  END : inclusive-or");
    }

    @Test
    public void testExclusion() throws Exception {
        System.out.println("* BEGIN: exclusion");

        SchemAnon tron = compileConstraints("/TestConstraints-exclusion.xml");

        System.out.println("- RECORD:hello (invalid)");

        assertTrue(validateRecord(tron, "/test-hello.xml"));

        System.out.println("- RECORD:hello eric (valid)");

        assertTrue(validateRecord(tron, "/test-hello_eric.xml"));

        System.out.println("- RECORD:hello clarin (valid)");

        assertTrue(validateRecord(tron, "/test-hello_clarin.xml"));

        System.out.println("- RECORD:hello clarin eric (valid)");

        assertFalse(validateRecord(tron, "/test-hello_clarin_eric.xml"));

        System.out.println("*  END : exclusion");
    }

    @Test
    public void testExclusiveOr() throws Exception {
        System.out.println("* BEGIN: exclusive-or");

        SchemAnon tron = compileConstraints("/TestConstraints-exclusive-or.xml");

        System.out.println("- RECORD:hello (invalid)");

        assertFalse(validateRecord(tron, "/test-hello.xml"));

        System.out.println("- RECORD:hello eric (valid)");

        assertTrue(validateRecord(tron, "/test-hello_eric.xml"));

        System.out.println("- RECORD:hello clarin (valid)");

        assertTrue(validateRecord(tron, "/test-hello_clarin.xml"));

        System.out.println("- RECORD:hello clarin eric (valid)");

        assertFalse(validateRecord(tron, "/test-hello_clarin_eric.xml"));

        System.out.println("*  END : exclusive-or");
    }

}