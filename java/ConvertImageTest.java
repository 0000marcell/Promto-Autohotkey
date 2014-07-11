import java.awt.Color;
import java.awt.image.BufferedImage;
import java.awt.Image;
import java.io.File;
import java.io.IOException;
import javax.imageio.ImageIO;
 
public class ConvertImageTest {
 
   public static void main(String[] args) {
			BufferedImage bufferedImage;
			BufferedImage newBufferedImage;
			Image image;

			try {
			  //read image file
			  bufferedImage = ImageIO.read(new File("test.jpg"));
			  //Resize the image 
				image = bufferedImage.getScaledInstance(400, 400, Image.SCALE_DEFAULT);	

			  // create a blank, RGB, same width and height, and a white background 
			  newBufferedImage = new BufferedImage(400,
					400, BufferedImage.TYPE_INT_RGB);
			  newBufferedImage.createGraphics().drawImage(image, 0, 0, Color.WHITE, null);

			  // write to jpeg file
			  ImageIO.write(newBufferedImage, "jpg", new File("result.jpg"));
			  System.out.println("Done");
			} catch (IOException e) {
		 		System.out.println("Um erro occorreu ao salvar a imagem!");
			  e.printStackTrace();
			}
   }
 
}