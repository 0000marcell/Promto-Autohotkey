import java.io.BufferedReader;
import java.io.FileReader;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JOptionPane;

public class ConvertImage{

	public static void main( String args[]){
		ConvertImage convertImage = new ConvertImage();
		String imagePath = convertImage.getImagePath();
		System.out.println("caminho da imagem " + imagePath);
		convertImage.convertImage(imagePath);
	}

	public void convertImage(String imagePath){
		BufferedImage bufferedImage;
 
		try {
	  	//read image file
	  	bufferedImage = ImageIO.read(new File(imagePath));
 
		  // create a blank, RGB, same width and height, and a white background
		  System.out.println("largura " + bufferedImage.getWidth() + " altura " + bufferedImage.getHeight());
	  	BufferedImage newBufferedImage = new BufferedImage(bufferedImage.getWidth(),
			bufferedImage.getHeight(), BufferedImage.TYPE_INT_RGB);
	  	newBufferedImage.createGraphics().drawImage(bufferedImage, 0, 0, Color.WHITE, null);
 
	  	// write to jpeg file
	  	ImageIO.write(newBufferedImage, "jpg", new File(imagePath));
	  	System.out.println("Done");
	  	JOptionPane.showMessageDialog(null, "A imagem foi convertida e inserida! ", "Informacao", 
	  		JOptionPane.INFORMATION_MESSAGE);
		} catch (IOException e) {
 			JOptionPane.showMessageDialog(null, e.toString(), "Erro", JOptionPane.ERROR_MESSAGE);
		}
	}

	public String getImagePath(){
		String returnValue = null;
		String line;
		try{
			BufferedReader reader = new BufferedReader(new FileReader("temp/image_info.txt"));
			while ((line = reader.readLine()) != null){
				System.out.println("valor da linha lida " + line);
				returnValue = line;
      	System.out.println(line + "\n");
    	}
    	reader.close(); 
		}catch(Exception e){
			JOptionPane.showMessageDialog(null, e.toString(), "Erro", JOptionPane.ERROR_MESSAGE);
		}	
		System.out.println(" valor que sera retornado" + returnValue);
		return returnValue;
	}
}
