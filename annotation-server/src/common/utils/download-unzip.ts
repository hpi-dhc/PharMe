import * as fs from 'fs';
import * as https from 'https';
import * as os from 'os';
import * as path from 'path';
import { v4 as uuidv4 } from 'uuid';
import * as yauzl from 'yauzl';

export const downloadAndUnzip = async (url: string, targetPath: string) => {
  const zipTempPath = path.join(os.tmpdir(), `${uuidv4()}.zip`);

  await download(url, zipTempPath);
  await unzip(zipTempPath, targetPath);
};

const download = (url: string, targetPath: string) => {
  return new Promise<void>((resolve) => {
    https.get(url, (res) => {
      const writeStream = fs.createWriteStream(targetPath);

      res.pipe(writeStream);

      writeStream.on('finish', () => {
        writeStream.close();
        resolve();
      });
    });
  });
};

const unzip = (zipPath: string, unzipTargetPath: string) => {
  return new Promise<void>((resolve, reject) => {
    try {
      // Create folder if not exists
      if (!fs.existsSync(unzipTargetPath)) {
        fs.mkdirSync(unzipTargetPath);
      }

      // Unzip file
      yauzl.open(zipPath, { lazyEntries: true }, (error, zipfile) => {
        if (error) {
          zipfile.close();
          reject(error);
          return;
        }

        // Read first entry
        zipfile.readEntry();

        // Trigger next cycle, every time we read an entry
        zipfile.on('entry', (entry) => {
          // Directories
          if (/\/$/.test(entry.fileName)) {
            // If it is a directory, it needs to be created
            const dirPath = path.join(unzipTargetPath, entry.fileName);
            if (!fs.existsSync(dirPath)) {
              fs.mkdirSync(dirPath);
            }
            zipfile.readEntry();
          }
          // Files
          else {
            zipfile.openReadStream(entry, (error, readStream) => {
              if (error) {
                zipfile.close();
                reject(error);
                return;
              }

              const filePath = path.join(unzipTargetPath, entry.fileName);
              const file = fs.createWriteStream(filePath);
              readStream.pipe(file);

              file.on('finish', () => {
                // Wait until the file is finished writing, then read the next entry.
                file.close(() => {
                  zipfile.readEntry();
                });
              });

              file.on('error', (error) => {
                zipfile.close();
                reject(error);
              });
            });
          }
        });

        zipfile.on('end', () => {
          resolve();
        });

        zipfile.on('error', (error) => {
          zipfile.close();
          reject(error);
        });
      });
    } catch (error) {
      reject(error);
    }
  });
};
