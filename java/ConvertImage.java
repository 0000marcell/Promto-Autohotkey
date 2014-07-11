import java.io.BufferedReader;
import java.io.FileReader;
import java.awt.Color;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JOptionPane;
import java.awt.Image;

public class ConvertImage{

	public static void main( String args[]){
		ConvertImage convertImage = new ConvertImage();
		String imagePath = convertImage.getImagePath();
		convertImage.convertImage(imagePath);
	}

	public void convertImage(String imagePath){
		BufferedImage bufferedImage;
 		BufferedImage newBufferedImage;
 		Image image;

		try {
	  	//read image file
	  	bufferedImage = ImageIO.read(new File(imagePath));
	  	//Resize the image
 			image = bufferedImage.getScaledInstance(448, 336, Image.SCALE_DEFAULT);
		  // create a blank, RGB, same width and height, and a white background
	  	newBufferedImage = new BufferedImage(448,
			336, BufferedImage.TYPE_INT_RGB);
	  	newBufferedImage.createGraphics().drawImage(image, 0, 0, Color.WHITE, null);
	  	// write to jpeg file
	  	ImageIO.write(newBufferedImage, "jpg", new File(imagePath));
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
				returnValue = line;
    	}
    	reader.close(); 
		}catch(Exception e){
			JOptionPane.showMessageDialog(null, e.toString(), "Erro", JOptionPane.ERROR_MESSAGE);
		}
		return returnValue;
	}
}
