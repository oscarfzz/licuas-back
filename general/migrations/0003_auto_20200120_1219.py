# Generated by Django 2.2.7 on 2020-01-20 11:19

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('general', '0002_auto_20191220_0843'),
    ]

    operations = [
        migrations.AlterUniqueTogether(
            name='obra',
            unique_together={('codigo', 'empresa')},
        ),
        migrations.AddIndex(
            model_name='obra',
            index=models.Index(fields=['codigo', 'empresa'], name='general_obr_codigo_da1d56_idx'),
        ),
    ]
